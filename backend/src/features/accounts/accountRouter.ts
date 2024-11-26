import { logIn, signUp, getAllUsers, updateUserAccount, searchServiceProvider, updateServiceAccount, subscribe  } from "./controller";
import { Router} from "express";
const accountRouter = Router()

accountRouter.post("/signup", signUp);
accountRouter.post("/login", logIn);
accountRouter.get("/all", getAllUsers);
accountRouter.post("/update", updateUserAccount);
accountRouter.post("/updateService", updateServiceAccount);
accountRouter.get("/search", searchServiceProvider);
accountRouter.post("/subscribe", subscribe);
export default accountRouter;
