import { logIn, signUp, getAllUsers, updateUserAccount, searchServiceProvider  } from "./controller";
import { Router} from "express";
const accountRouter = Router()

accountRouter.post("/signup", signUp);
accountRouter.post("/login", logIn);
accountRouter.get("/all", getAllUsers);
accountRouter.put("/update", updateUserAccount);
accountRouter.get("/search", searchServiceProvider);
export default accountRouter;
