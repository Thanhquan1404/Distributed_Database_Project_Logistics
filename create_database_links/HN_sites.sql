connect C##M01;

-- INITIALIZE DATABASE LINKS
--- Thanh Quan Database link (DN)
DROP DATABASE LINK ThanhQuan_Oracle_DistributedDatabase;

CREATE DATABASE LINK ThanhQuan_Oracle_DistributedDatabase 
CONNECT TO SYSTEM IDENTIFIED BY "Quannguyen@14042005!"
USING '(
    DESCRIPTION=(
        ADDRESS=
            (PROTOCOL=TCP)
            (HOST=100.122.81.2)
            (PORT=1521)
            (CONNECT_DATA=(SERVICE_NAME=FREE))
    )
)';
--- Check Kim Ngan connection 
select * from Products@ThanhQuan_Oracle_DistributedDatabase;

--- Kim Ngan Database link (HCM)
DROP DATABASE LINK KimNgan_Oracle_DistributedDatabase;

CREATE DATABASE LINK KimNgan_Oracle_DistributedDatabase 
CONNECT TO SYSTEM IDENTIFIED BY "Kimngan@2352129"
USING '(
    DESCRIPTION=(
        ADDRESS=
            (PROTOCOL=TCP)
            (HOST=100.127.201.25)
            (PORT=1521)
            (CONNECT_DATA=(SERVICE_NAME=FREE))
    )
)';
--- Check Kim Ngan connection 
select * from Products@KimNgan_Oracle_DistributedDatabase;
