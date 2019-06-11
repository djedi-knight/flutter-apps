const functions = require('firebase-functions');
const fs = require('fs');
const os = require('os');
const path = require('path');

const cors = require('cors')({
  origin: true
});
const Busboy = require('busboy');
const firebaseAdmin = require('firebase-admin');
const uuid = require('uuid/v4');

const gcconfig = {
  projectId: 'fluttercourse-c2b8e',
  keyFilename: 'config.json'
};
const gcs = require('@google-cloud/storage')(gcconfig);

firebaseAdmin.initializeApp({
  credential: firebaseAdmin.credential.cert(require('./config.json'))
});

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.storeImage = functions.https.onRequest((request, response) => {
  return cors(request, response, () => {
    if (request.method !== 'POST') {
      return response.status(500).json({
        message: 'Not allowed.'
      });
    }

    if (!request.headers.authorization || !request.headers.authorization.startsWith('Bearer ')) {
      return response.status(401).json({
        error: 'Unauthorized.'
      });
    }

    const idToken = request.headers.authorization.split('Bearer ')[1];

    const busboy = new Busboy({
      headers: request.headers
    });

    let uploadData;
    let oldImagePath;

    busboy.on('file', (fieldName, file, fileName, encoding, mimeType) => {
      const filePath = path.join(os.tmpdir(), fileName);
      uploadData = {
        filePath: filePath,
        type: mimeType,
        name: fileName
      };
      file.pipe(fs.createWriteStream(filePath));
    });

    busboy.on('field', (fieldName, value) => {
      oldImagePath = decodeURIComponent(value);
    });

    busboy.on('finish', () => {
      const bucket = gcs.bucket('fluttercourse-c2b8e.appspot.com');
      const id = uuid();
      let imagePath = 'images/' + id + '-' + uploadData.name;

      if (oldImagePath) {
        imagePath = oldImagePath;
      }

      return firebaseAdmin
        .auth()
        .verifyIdToken(idToken)
        .then(decodedToken => {
          return bucket.upload(uploadData.filePath, {
            uploadType: 'media',
            desination: imagePath,
            metadata: {
              metadata: {
                contentType: uploadData.type,
                firebaseStorageDownloadToken: id
              }
            }
          });
        })
        .then(() => {
          return response.statusCode(201).json({
            imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/' +
              bucket.name +
              '/o/' +
              encodeURIComponent(imagePath) +
              '?alt=media&token=' +
              id,
            imagePath: imagePath
          });
        })
        .catch(error => {
          return response.statusCode(401).json({
            error: 'Unauthorized.'
          });
        });
    });
    
    return busboy.end(request.rawBody);
  });
}); 