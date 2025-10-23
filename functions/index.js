const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Отправляет тестовое уведомление всем сотрудникам, связанным с заданным промо-кодом.
 * * !!! ВАЖНОЕ ПРИМЕЧАНИЕ ПО БЕЗОПАСНОСТИ:
 * Опция allowInvalidAppCheckToken: true ОТКЛЮЧАЕТ App Check
 * для этой функции. Это может привести к злоупотреблению и высоким счетам.
 * Используйте это на свой страх и риск.
 */
exports.sendTestNotification = functions
    .runWith({
        // Отключение проверки App Check
        allowInvalidAppCheckToken: true
    })
    .https.onCall(async (data, context) => {
        const promoCode = data.promoCode;
        const title = data.title;
        const body = data.body;

        // Проверка обязательных аргументов
        if (!promoCode || !title || !body) {
            console.error('Missing arguments:', { promoCode, title, body });
            throw new functions.https.HttpsError('invalid-argument', 'The function must be called with "promoCode", "title", and "body" arguments.');
        }

        // Поиск всех пользователей с данным промо-кодом
        const usersSnapshot = await admin.firestore().collection('users').where('promoCode', '==', promoCode).get();

        const tokens = [];
        usersSnapshot.forEach(userDoc => {
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
                // Можно добавить data-payload для обработки в фоновом режиме
                data: {
                    type: 'company_message',
                    promo: promoCode
                }
            };

            // Отправка уведомления на все устройства
            const response = await admin.messaging().sendToDevice(tokens, payload);
            console.log('Successfully sent message:', response);

            // Логирование результатов, чтобы увидеть, какие токены были недействительны
            response.results.forEach((result, index) => {
                const error = result.error;
                if (error) {
                    console.error('Failure sending notification to token:', tokens[index], error);
                }
            });

            return { success: true, message: `Notifications sent successfully to ${response.successCount} of ${tokens.length} tokens.` };
        } else {
            console.log('No tokens found for the given promo code.');
            return { success: false, message: 'No tokens found.' };
        }
    });