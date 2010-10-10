def ikari(shinji,yui=1):
    if shinji < 2:
        return yui
    else:
        return ikari(shinji-1,shinji*yui)


print ikari(0)
