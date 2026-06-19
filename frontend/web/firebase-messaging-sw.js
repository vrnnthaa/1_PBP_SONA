importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBgSzJAFKNxsQdVsrkkFbygl5eLApFzDLo",
  authDomain: "sona-dfee3.firebaseapp.com",
  projectId: "sona-dfee3",
  storageBucket: "sona-dfee3.firebasestorage.app",
  messagingSenderId: "388389040333",
  appId: "1:388389040333:web:8aa53c9fb210e654bef984"
  
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Received background message ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/favicon.png"
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});
