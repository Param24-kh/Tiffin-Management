import Router from 'express';
import accountRouter from './features/accounts/accountRouter'
const apiRouter = Router();
apiRouter.use('/auth', accountRouter);




export default apiRouter;