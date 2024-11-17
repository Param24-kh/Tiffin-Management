import Router from 'express';
import accountRouter from './features/accounts/accountRouter'
import pollRouter from './features/polling/pollingRouter';
import vasRouter from './features/vas/vasRouter';
const apiRouter = Router();
apiRouter.use('/auth', accountRouter);
apiRouter.use('/poll', pollRouter);
apiRouter.use('/vas', vasRouter);


export default apiRouter;