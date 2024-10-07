import { createCenter, logIn } from "./controller";
import { Router} from "express";
const accountRouter = Router()

accountRouter.post("/createCenter", createCenter);
accountRouter.post("/login", logIn);

export default accountRouter;
