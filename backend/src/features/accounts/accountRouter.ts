import { logIn, signUp, getAllUsers } from "./controller";
import { Router} from "express";
const accountRouter = Router()

accountRouter.post("/signup", signUp);
accountRouter.post("/login", logIn);
accountRouter.get("/all", getAllUsers);
export default accountRouter;
