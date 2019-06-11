const functions = require('firebase-functions');
const fs = require('fs');
const os = require('os');
const path = require('path');

const cors = require('cors')({ origin: true });
const Busboy = require('busboy');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.storeImage = functions.https.onRequest((request, response) => {
  return cors(request, response, () => {
    if (request.method !== 'POST') {
      return response.status(500).json({ message: 'Not allowed.' });
    }

    if (!request.headers.authorization || !request.headers.authorization.startsWith('Bearer ')) {
      return response.status(401).json({ error: 'Unauthorized.' });
    }

    let idToken = request.headers.authorization.split('Bearer ')[1];

    const busboy = new Busboy({ headers: request.headers });

    let uploadData;
    let oldImagePath;

    busboy.on('file', (fieldName, file, fileName, encoding, mimeType) => {
      const filePath = path.join(os.tmpdir(), fileName);
      uploadData = { filePath: filePath, type: mimeType, name: fileName };
      file.pipe(fs.createWriteStream(filePath));
    });

    busboy.on('field', (fieldName, value) => {
      oldImagePath = decodeURIComponent(value);
    });

    busboy.on('finish', () => {});
  });
}); 