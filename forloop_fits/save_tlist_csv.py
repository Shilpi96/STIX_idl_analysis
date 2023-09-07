import datetime,pdb,csv,pandas

#### split into 13 time intervals
tinterval = 13
tlist = [datetime.datetime(2022,11,11,11,36,1,550000)+ datetime.timedelta(seconds = 3*i) for i in range(tinterval)]


df = pandas.DataFrame(data={"col1": tlist})
pdb.set_trace()
df.to_csv("/home/shilpi/stix_idl_files/testing1/timefile.csv", sep=',',index=False)
