#sgong, ahthorship attribution
import pandas as pd
import pymysql # Linux Windows 都可以用, 可以导入，不能导出， 导出还得要 mysqldb
 
con = pymysql.connect(host='localhost', user='root', passwd='qwer', db='amazon', port = 3306) # 连接
cur = con.cursor()
 
def read_table(cur, sql_order): # sql_order is a string
    try:
        cur.execute(sql_order) # 多少条记录
        data  = cur.fetchall(  )
        frame = pd.DataFrame(list(data))
    except: #, e:
        frame = pd.DataFrame()
        # print e
        # continue 
    return frame
 
pd = read_table(cur,'select * from mytest')
print(pd)














#con.commit()
cur.close()
con.close()


