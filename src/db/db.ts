    import {
        MongoClient,
        Db,
        Collection,
        Document,
        MongoNetworkError,
        MongoNetworkTimeoutError,
    } from 'mongodb';
    const URI = 'mongodb+srv://RishabhMaheshwari10:WZPmByJH7rN1PA9k@rishabhcluster03.yxquylw.mongodb.net/rishabhDB?retryWrites=true&w=majority';
    const mongoClient = new MongoClient(URI);

    export async function connectMongoDb() {
        try{
            const db = await mongoClient.connect();
            console.log("Connected to DB");
            return db;
        }catch(error:any){
            console.log("Error in connecting DB"+error);
            throw error;
        }
    }

    export async function closeMongoDB() {
        try {
        await mongoClient.close();
        console.log("MongoDB connection closed");
        } catch (error) {
        console.error("Error closing MongoDB connection:", error);
        throw error;
        }
    }
    
    export async function mongoErrorHander(
        error: Error | any,
        message: string,
        message2: string
    ) {
        if (
        error instanceof MongoNetworkError ||
        error instanceof MongoNetworkTimeoutError
        ) {
        await mongoClient.connect().then(() => {
            console.error(message, error);
        });
        } else {
        console.error(message2, error, error.stack);
        }
    }
    
    async function connect() {
        await mongoClient.connect();
    }
    
    export async function getCollection<T extends Document>(collectionName: string,dbname: string | undefined | null
    ): Promise<Collection<T>> {
        await connect();
        const db: Db = mongoClient.db(getDbName(dbname));
        return db.collection<T>(collectionName);
    }
    
    export async function disConnect() {
        await mongoClient.close();
    }
    function getDbName(dbname: string | undefined | null) {
        // Check if dbname is null, "null", undefined, or "undefined"
        if (dbname == null || dbname === "null" || dbname === "undefined" || !dbname) {
        return "CommonDatabase"; // default database name
        } else {
        return dbname + "_db"; // concatenate the provided name with "_db"
        }
    }
    