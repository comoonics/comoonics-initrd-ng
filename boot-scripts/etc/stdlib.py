import stat
import os
import os.path
def get_files_newer(_file, _map_paths={ "." : "/" , "/": "/"}, prefix="@mapfile", delimiter="\n"):
    for _line in _file:
        _line=_line[:-1]+";"
        (_file1, _mtime1)=_line.split(";")[0:2]
        (_file2, _mtime2, _path_from, _map_to)=find_file(_file1, _map_paths)
        if _file1 and _file2 and is_newer(_file1, _mtime1, _file2, _mtime2):
            if _path_from != _map_to:
                print prefix+delimiter+_file2+delimiter+_path_from+delimiter+_map_to
            else:
                print _file2
            
def find_file(_file, _map_paths={ "." : "/", "/":"/" }):
    for _path, _map_to in _map_paths.items():
        _fullfile=os.path.join(_path, _file)
        if os.path.exists(_fullfile):
            return (_fullfile, None, _path, _map_to)
    return (None, None, None, None)

def is_newer(_file1, _mtime1, _file2, _mtime2):
    if not _mtime1:
        _mtime1=int(os.stat(_file1)[stat.ST_MTIME])
    else:
        _mtime1=int(float(_mtime1))
    if not _mtime2:
        _mtime2=int(os.stat(_file2)[stat.ST_MTIME])
    else:
        _mtime2=int(float(_mtime2))

#    print "is_newer: %s<%u> == %s<%u>" %(_file1, _mtime1, _file2, _mtime2)
    
    if _mtime1 < _mtime2:
        return True
    else:
        return False              