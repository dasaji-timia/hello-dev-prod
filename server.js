require('dotenv').config();
const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;
const MESSAGE = process.env.HELLO_MESSAGE || 'Hello World';

app.get('/', (req, res) => {
    res.send(MESSAGE);
});

app.listen(PORT, () => {
    console.log(`Serr running on http://localhost:${PORT}`);
});
