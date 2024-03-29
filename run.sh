source env.rc

source common/commonproc.sh
source common/db2commonproc.sh
source common/oraclecommonproc.sh

touchlogfile
usetemp

XMLTABLE=IDXML
TEMPVARCHAR=IDTEMP

# -------------------------------------------
# DB2 
# -------------------------------------------

db2testconn() {
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
DROP TABLE IF EXISTS $XMLTABLE;
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
DROP TABLE IF EXISTS $XMLTABLE;
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
      echo $id$COLDEL$XMLFILE >>$CSVFILE
    done
    log "$CSVFILE Done"

}

load() {
    db2connect
    db2loadblobs $LOADDIR/$CSVFILE $LOADXMLDIR $XMLTABLE
    db2terminate
}

db2copyvar() {
    db2connect
    local -r TMPF=`crtemp`    
    log "Copying XML table $XMLTABLE to $TEMPVARCHAR"
cat << EOF  >$TMPF
   DROP TABLE IF EXISTS $TEMPVARCHAR;
   CREATE TABLE $TEMPVARCHAR AS (SELECT ID, trim(xmlserialize(books as varchar(10000))) AS books from $XMLTABLE) WITH DATA NOT LOGGED INITIALLY;
   DROP TABLE $XMLTABLE;
   RENAME TABLE $TEMPVARCHAR TO $XMLTABLE;
EOF
    db2runscript $TMPF

    db2terminate

}

# -------------------------------------------------------
# Oracle
# -------------------------------------------------------

oracledroptable() {
    oraclecommand "DROP TABLE $XMLTABLE"
}

oraclecreatetable() {
    local -r TMPF=`crtemp`

cat << EOF  >$TMPF
CREATE TABLE $XMLTABLE (ID INT PRIMARY KEY NOT NULL, BOOKS XMLTYPE);
EOF
    oraclescript $TMPF

}

oraclegenerate() {
    local TEMPXML=$(cat resource/books.xml | tr -d "\n")
    rm -f $CSVFILE
    log "Generate $CSVFILE  $SIZE rows"
    for id in $(seq 1 $SIZE); do
      echo $id $COLDEL $TEMPXML >>$CSVFILE
    done
}

# ---------------------------------------

rundb2() {
    #db2testconn
    droptable
    createtable
    #createpartitionedtable
    #generate
    load
    db2copyvar
    log "OK"      

}

#oracleloadfile $XMLTABLE inxml.csv

oracle() {
    #oracletestconnection
    #oracledroptable
    #oraclecreatetable
    #oraclegenerate
    oracleloadfile $XMLTABLE $CSVFILE
    log "OK"      
}

#oracle
rundb2