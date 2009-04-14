import stdlib
import StringIO
import os
import os.path
import sys

paths=[ ["test/test1" , "test/test2" ],
        ["test/test2" , "test/test1" ] ]

buffer1=StringIO.StringIO()
buffer1.write("test1\n")
buffer1.write("test2\n")

oldpath=os.path.dirname(sys.argv[0])
for path in paths:
    os.chdir(path[0])
    stdlib.get_files_newer(StringIO.StringIO(buffer1.getvalue()), { os.path.join("../..", path[1]): "/", "/":"/" })
    os.chdir(oldpath)