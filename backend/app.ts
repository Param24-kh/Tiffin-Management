import express from 'express'
const PORT = 3000;
const app = express();
import http from 'http';
import {Server} from 'socket.io';
const server = http.createServer(app);
import cors from 'cors';
import apiRouter from './src/apiRouter';
import { AddressInfo } from 'net';


export const io = new Server(server,{
    cors: {
        origin: '*',
        methods: ['GET', 'POST', 'PUT', 'DELETE']
    }
});





app.use(express.json());
app.use(cors(
    {
        origin: '*'
    }
))
app.use('/api', apiRouter);



server.listen(PORT, () => {
    const address = server.address() as AddressInfo;
    console.log(`Server is running on port http://192.168.1.2:${PORT}`);
})
