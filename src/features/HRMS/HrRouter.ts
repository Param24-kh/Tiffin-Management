import { addEmployee, updateAttendance, updateEmployee, addRemark, deleteEmployee, getEmployee } from "./HRController";
import { Router } from "express";

const hrRouter = Router();

hrRouter.post("/addEmployee", addEmployee);
hrRouter.get("/getEmployee", getEmployee);
hrRouter.put("/updateEmployee", updateEmployee);
hrRouter.post("/updateAttendance", updateAttendance);
hrRouter.post("/addRemark", addRemark);
hrRouter.delete("/deleteEmployee", deleteEmployee);

export default hrRouter