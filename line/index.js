const express = require('express')
const bodyParser = require('body-parser');
const path = require('path')
const PORT = process.env.PORT || 5000
const line = require('@line/bot-sdk');
const config = {
  channelAccessToken: process.env.ACCESS_TOKEN,
  channelSecret: process.env.SECRET_KEY
};
const client = new line.Client(config);

express()
  .use(bodyParser.urlencoded({ extended: true }))
  .use(express.static(path.join(__dirname, 'public')))
  .set('views', path.join(__dirname, 'views'))
  .set('view engine', 'ejs')
  .get('/', (req, res) => res.render('pages/index'))
  .post('/linepush/', (req, res) => therapistAttack(req))
  .post('/userinfo/', line.middleware(config), (req, res) => getUserInfo(req, res))
  .listen(PORT, () => console.log(`Listening on ${ PORT }`))

function therapistAttack(req) {
  //  let userId = 'Ud6e97f08e338acefe029dcf9f91b1f24';
    let userId = req.body.userId;
    let therapyText = req.body.message;
    const message = {
        type: 'text',
        text: `${therapyText}`
    };
    
    client.pushMessage(userId, message)
      .then(() => {
        console.log('OK');
      })
      .catch((err) => {
        console.log(err);
      });
}

function getUserInfo(req, res) {
  res.status(200).end();
  const events = req.body.events;
  const promises = [];
  for (let i=0, l=events.length ; i<l ; i++) {
    const ev = events[i];
    promises.push(
      echoman(ev)
    );
  }
  Promise.all(promises).then(console.log("pass"));
}

async function echoman(ev) {
  const pro =  await client.getProfile(ev.source.userId);
  return client.replyMessage(ev.replyToken, {
    type: "text",
    text: `userId： ${ev.source.userId} \n 名前： ${pro.displayName} \n ステータスメッセージ： ${pro.statusMessage}`
  })
}
