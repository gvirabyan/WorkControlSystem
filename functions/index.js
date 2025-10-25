const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Отправляет тестовое уведомление всем сотрудникам, связанным с заданным промо-кодом.
 * V2-версия функции с корректным применением опции allowInvalidAppCheckToken.
 */
exports.sendTestNotification = onCall(
  {
    // Эта опция отключает App Check для данной функции.
    // Используйте с осторожностью, так как это может привести к злоупотреблениям.
    allowInvalidAppCheckToken: true,
  },
  async (request) => {
    // Данные приходят в request.data
    const data = request.data;
    const promoCode = data.promoCode;
    const title = data.title;
    const body = data.body;

    // Проверка обязательных аргументов
    if (!promoCode || !title || !body) {
      console.error("Missing arguments:", { promoCode, title, body });
      throw new HttpsError(
        "invalid-argument",
        'The function must be called with "promoCode", "title", and "body" arguments.'
      );
    }

    // Поиск всех пользователей с данным промо-кодом
    const usersSnapshot = await admin
      .firestore()
      .collection("users")
      .where("promoCode", "==", promoCode)
      .get();

    const tokens = [];
    usersSnapshot.forEach((userDoc) => {
      const token = userDoc.data().fcmToken;
      if (token) {
        tokens.push(token);
      }
    });

    if (tokens.length > 0) {
      // Формирование полезной нагрузки для уведомления
      const payload = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: "company_message",
          promo: promoCode,
        },
      };

      // Отправка уведомления на все устройства
      const response = await admin.messaging().sendToDevice(tokens, payload);
      console.log("Successfully sent message:", response);

      // Логирование результатов
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error(
            "Failure sending notification to token:",
            tokens[index],
            error
          );
        }
      });

      return {
        success: true,
        message: `Notifications sent successfully to ${response.successCount} of ${tokens.length} tokens.`,
      };
    } else {
      console.log("No tokens found for the given promo code.");
      return { success: false, message: "No tokens found." };
    }
  }
);
