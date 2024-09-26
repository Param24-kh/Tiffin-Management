export interface IEmployee{
    centerId:string;
    employeeId:string;
    employeeName:string;
    employeeAddress:string;
    employeeContact:number;
    employeeEmail:string;
    employeeRole:IRole;
    employeeSalary:number;
    employeeJoiningDate:string;
    employeeLeavingDate:string;
    employeeAttendance:IEmployeeAttendance[];
    employeeRemark:IRemark[];
}

export enum IRole{
    CHEF = "chef",
    DELIVERY = "delivery"
}

export interface IEmployeeAttendance{
    date:string;
    attendance:boolean;
}

export interface IRemark{
    remark:string;
    createdDate:string;
}