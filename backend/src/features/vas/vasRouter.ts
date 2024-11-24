import { Router } from 'express';
import {purchaseService, getServices, addService, updateService, deleteService} from './vasController';

const vasRouter = Router();

vasRouter.post('/purchase', purchaseService);
vasRouter.get('/getServices', getServices);
vasRouter.post('/addService', addService);
vasRouter.put('/updateService', updateService);
vasRouter.delete('/deleteService', deleteService);

export default vasRouter;