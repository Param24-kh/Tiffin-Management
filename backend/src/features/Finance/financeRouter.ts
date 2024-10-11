import {getFinance,createFinance, updateFinance} from './financeController'
import { Router } from 'express';
const financeRouter = Router();

financeRouter.route("/getfinance").get(getFinance);
financeRouter.route("/createfinance").post(createFinance);
financeRouter.route("/updatefinance").put(updateFinance);

export default financeRouter
