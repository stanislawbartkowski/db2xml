source env.rc

source common/commonproc.sh
source common/db2commonproc.sh

touchlogfile
usetemp

XMLTABLE=IDXML

testconn() {
    db2connect
    db2terminate
}

droptable() {
    db2connect
    db2 drop table $XMLTABLE
    db2terminate
}

createtable() {
    db2connect
    local -r TMPF=`crtemp`

cat << EOF  >$TMPF
CREATE TABLE IF NOT EXISTS $XMLTABLE (ID INT PRIMARY KEY NOT NULL, BOOKS XML $INLINE) ORGANIZE BY ROW;
EOF
    db2runscript $TMPF

    db2terminate

}

#db2 CREATE BUFFERPOOL BP16   PAGESIZE 16K;
#db2 CREATE TABLESPACE TS16   PAGESIZE 16K BUFFERPOOL BP16

createpartitionedtable() {
    db2connect
    local -r TMPF=`crtemp`

cat << EOF  >$TMPF
CREATE TABLE IF NOT EXISTS $XMLTABLE (ID INT PRIMARY KEY NOT NULL, BOOKS XML $INLINE) ORGANIZE BY ROW 
  PARTITION BY RANGE (ID) (STARTING FROM (1)  INCLUSIVE ENDING AT ($SIZE) EVERY ($PARTITIONEVERY));
EOF
    db2runscript $TMPF

    db2terminate

}


generate() {

    log "Generuj $SIZE lines in file $CSVFILE"
    rm -f $CSVFILE
    for id in $(seq 1 $SIZE); do
      echo $id,$XMLFILE >>$CSVFILE
    done
    log "$CSVFILE Done"

}

load() {
    db2connect
    db2loadblobs $LOADDIR/$CSVFILE $LOADXMLDIR $XMLTABLE
    db2terminate
}

#testconn
#droptable
#createtable
#createpartitionedtable
#generate
load