export interface IFinance{
    centerId:string;
    date:string;
    income:IIncome;
    expense:IExpense;
}

export interface IExpense{
    TotalExpenses:number;
    TotalSalary:number;
    TotalVasExpenses:number;
    TotalMiscellaneousExpenses:number;
    expense:Expense[];
}

export interface IIncome{
    TotalSalesPerDay:number;
    TiffinSoldPerDay:number;
    AmountCollectedFromVas:number;
}

export interface Expense{
    ExpenseId:string;
    ExpenseName:string;
    Amount:number;
    Date:string;
}