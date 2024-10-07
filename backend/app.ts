import express from 'express'
const PORT = 3000;
const app = express();
import http from 'http';
import {Server} from 'socket.io';
const server = http.createServer(app);
const io = new Server(server);
import apiRouter from './src/apiRouter';


server.listen(PORT, () => {
    console.log(`Server is running on port http://localhost:${PORT}`);
})
