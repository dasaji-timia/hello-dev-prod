require('dotenv').config();
const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;
const MESSAGE = process.env.HELLO_MESSAGE || 'Hello World-dev1';

app.get('/', (req, res) => {
    res.send(MESSAGE);
});

app.listen(PORT, () => {
    console.log(`Serr testung-dev-prod on http://localhost:${PORT}`);
});
