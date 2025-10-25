importScripts("https://www.gstatic.com/firebasejs/9.2.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.2.0/firebase-messaging-compat.js");

const firebaseConfig = {
    apiKey: "AIzaSyCamdUfFKi-lRpH4iJ9rOufA7hrUujEDDk",
    authDomain: "pot-proj.firebaseapp.com",
    projectId: "pot-proj",
    storageBucket: "pot-proj.appspot.com",
    messagingSenderId: "149923852085",
    appId: "1:149923852085:web:32002177b88da8ab7ea67c"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();