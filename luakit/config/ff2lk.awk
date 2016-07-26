# Notes: 'folders' for Firefox bookmarks mean 'groups' for Luakit.

# Put spaces where it is needed to delimit words properly.
{gsub(/\"/," ")}

# Since the folder name may have spaces, delimiter must be ">" here.
/<\/H3>/ {
    FS=">"
    gsub(/</,">")
    oldgroup=group
    group=$(NF-2)
    FS=" "
}

# Each time a <DL> is encountered, it means we step into a subfolder.
# 'count' is the depth level.
# Base level starts at 2 (Firefox fault).
# 'groupline' is an array of all parent folders.
/<DL>/ {
    count++
    if ( count >= 3 )
        groupline[count-3]=group
}

# On </DL>, we step out.
# If if return to the base level (i.e. not in a folder), then we give 'group' a fake name different
# from 'oldgroup' to make sure a line will be skipped (see below).
/<\/DL>/ {
    count--
    if( count == 2 )
        group=oldgroup"ROOT"
}

# The bookmark name.
# If oldgroup is different than group, (i.e. folder changed) then we skip a line.
# If we are in a folder, then we print the group name, i.e. all parents plus the current folder
# separated by an hyphen.
/HREF/ {
    gsub(/</," ")
    gsub(/>/," ")
    if (group != "")
    {
        if(oldgroup != group)
        {
            printf "\n"
            oldgroup=group
        }
        printf "%s\t",$4
        if ( count >= 3 )
        {
            for ( i=0 ; i <= count-4 ; i++ )
            {printf "%s-" , groupline[i]}
            printf "%s" , groupline[count-3]
        }
        printf "\n"
    }
}