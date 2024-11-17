import { IEmployee, IRole, IEmployeeAttendance, IRemark } from "./HRModel";
import { ObjectId } from "mongodb";
import { Request, Response } from "express";
import { getCollection } from "db/db";



export const addEmployee = async (req: Request, res: Response) => {
    try{
        const {
            centerId,
            employeeId,
            employeeName,
            employeeAddress,
            employeeContact,
            employeeEmail,
            employeeRole,
            employeeSalary,
            employeeJoiningDate,
            employeeLeavingDate,
            employeeAttendance,
            employeeRemark
        } = req.body;
        
        const employee: IEmployee = {
            centerId: centerId?.toString(),
            employeeId,
            employeeName,
            employeeAddress,
            employeeContact,
            employeeEmail,
            employeeRole,
            employeeSalary,
            employeeJoiningDate ,
            employeeLeavingDate: "",
            employeeAttendance: [],
            employeeRemark: []
        } 
        const employeeColl = await getCollection<IEmployee>("Employee", centerId?.toString());
        const result = await employeeColl.insertOne(employee);
        if(!result){
            return res.status(500).json({
                success: false,
                message: "Employee not added, Internal Server Error"
            });
        }
        return res.status(201).json({
            success: true,
            message: "Employee added successfully",
            data: result
        })
    }catch(error:any){
        console.error("Error in addEmployee", error);
        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
}

export const getEmployee = async (req: Request, res: Response) => {
    try{
        const {centerId} = req.query;
        const employeeColl = await getCollection<IEmployee>("Employee", centerId?.toString());
        const employees = await employeeColl.find({}).toArray();
        if(!employees){
            return res.status(404).json({
                success: false,
                message: "No employees found"
            });
        }
        return res.status(200).json({
            success: true,
            message: "Employees found",
            data: employees
        });
    }catch(error:any){
        console.error("Error in getEmployee", error);
        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
}

export const updateAttendance = async (req: Request, res: Response) => {
    try{
        const {centerId, empId} = req.query;
        const mongoId = new ObjectId(empId as string);
        const {date, attendance} = req.body;
        const employeeColl = await getCollection<IEmployee>("Employee", centerId?.toString());
        const employee = await employeeColl.updateOne(
            { _id: mongoId },
            { $push: { employeeAttendance: { date, attendance } } }
        );
        if(!employee){
            return res.status(404).json({
                success: false,
                message: "Employee not found"
            });
        }
        return res.status(200).json({
            success: true,
            message: "Attendance updated successfully",
            data: employee
        });
    }catch(error:any){
        console.error("Error in updateAttendance", error);
        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
}

export const addRemark = async (req: Request, res: Response) => {
    try{
        const {centerId, empId} = req.query;
        const mongoId = new ObjectId(empId as string);
        const { remark, createdDate } = req.body;
        const data: IRemark = { remark, createdDate };
        const employeeColl = await getCollection<IEmployee>("Employee", centerId?.toString());
        const employee = await employeeColl.updateOne(
            { _id: mongoId },
            { $push: { employeeRemark: data } }
        );
        if(!employee){
            return res.status(404).json({
                success: false,
                message: "Employee not found"
            });
        }
        return res.status(200).json({
            success: true,
            message: "Remark added successfully",
            data: employee
        });

    }catch(error:any){
        console.error("Error in addRemark", error);
        return res.status(500).json({
            success:false,
            message: error.message
        })
    }
}

export const updateEmployee = async (req: Request, res: Response) => {
    try{
        const {centerId, empId} = req.query;
        const mongoId = new ObjectId(empId as string);
        const {
            employeeId,
            employeeName,
            employeeAddress,
            employeeContact,
            employeeEmail,
            employeeRole,
            employeeSalary,
            employeeJoiningDate,
            employeeLeavingDate,
            employeeAttendance,
            employeeRemark
        } = req.body;
        const employeeColl = await getCollection<IEmployee>("Employee", centerId?.toString());
        const employee = await employeeColl.updateOne(
            { _id: mongoId },
            {
                $set: {
                    employeeId,
                    employeeName,
                    employeeAddress,
                    employeeContact,
                    employeeEmail,
                    employeeRole,
                    employeeSalary,
                    employeeJoiningDate,
                    employeeLeavingDate,
                    employeeAttendance,
                    employeeRemark
                }
            }
        );
        if(!employee){
            return res.status(404).json({
                success: false,
                message: "Employee not found"
            });
        }
        return res.status(200).json({
            success: true,
            message: "Employee updated successfully",
            data: employee
        });
    }catch(error:any){
        console.error("Error in updateEmployee", error);
        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
}

export const deleteEmployee = async (req: Request, res: Response) => {
    try{
        const {centerId, empId} = req.query;
        const mongoId = new ObjectId(empId as string);
        const employeeColl = await getCollection<IEmployee>("Employee", centerId?.toString());
        const employee = await employeeColl.deleteOne({ _id: mongoId });
        if(!employee){
            return res.status(404).json({
                success: false,
                message: "Employee not found"
            });
        }
        return res.status(200).json({
            success: true,
            message: "Employee deleted successfully",
            data: employee
        });
    }catch(error:any){
        console.error("Error in deleteEmployee", error);
        return res.status(500).json({
            success: false,
            message: error.message
        })
    }
}