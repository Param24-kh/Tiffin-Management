import { logIn, signUp } from "./controller";
import { Router} from "express";
const accountRouter = Router()

accountRouter.post("/signup", signUp);
accountRouter.post("/login", logIn);

export default accountRouter;
