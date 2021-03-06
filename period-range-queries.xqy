xquery version "1.0-ml";
module namespace prq = "http://marklogic.com/query/period-range-query";

declare variable $ALN_EQUALS := 1;
declare variable $ALN_CONTAINS := 2;
declare variable $ALN_CONTAINED_BY := 3;
declare variable $ALN_MEETS := 4;
declare variable $ALN_MET_BY := 5;
declare variable $ALN_BEFORE := 6;
declare variable $ALN_AFTER := 7;
declare variable $ALN_STARTS := 8;
declare variable $ALN_STARTED_BY := 9;
declare variable $ALN_FINISHES := 10;
declare variable $ALN_FINISHED_BY := 11;
declare variable $ALN_OVERLAPS := 12;
declare variable $ALN_OVERLAPPED_BY := 13;

declare variable $ISO_OVERLAPS := 20;
declare variable $ISO_CONTAINS := 21;
declare variable $ISO_PRECEDES := 22;
declare variable $ISO_SUCCEEDS := 23;
declare variable $ISO_IMM_PRECEDES := 24;
declare variable $ISO_IMM_SUCCEEDS := 25;
declare variable $ISO_EQUALS := 26;

(:~
 : This function composes a period range query based on ALLEN operators
 :
 : @param  $xstart  qualified element name for the start dateTime
 : @param  $xend    qualified element name for the end dateTime
 : @param  $operator  any one of the ALLEN operators
 : @param  $ystart  dateTime value to use as start of period
 : @param  $yend    dateTime value to use as teh end of the period
 : @return  cts:query element combining the date queries
 :)
declare function prq:period-range-query(
        $xstart as xs:QName,
        $xend as xs:QName,
        $operator as xs:integer,
        $ystart as xs:dateTime,
        $yend as xs:dateTime
) as cts:query?
{
    switch ($operator)
        case $ISO_EQUALS
        case $ALN_EQUALS
            return prq:aln-equals-dt($xstart, $xend, $ystart, $yend)
        case $ALN_CONTAINS
            return prq:aln-contains-dt($xstart, $xend, $ystart, $yend)
        case $ALN_CONTAINED_BY
            return prq:aln-contained-by-dt($xstart, $xend, $ystart, $yend)
        case $ISO_IMM_PRECEDES
        case $ALN_MEETS
            return prq:aln-meets-dt($xend, $ystart)
        case $ISO_IMM_SUCCEEDS
        case $ALN_MET_BY
            return prq:aln-met-by-dt($xstart, $yend)
        case $ALN_BEFORE
            return prq:aln-before-dt($xend, $ystart)
        case $ALN_AFTER
            return prq:aln-after-dt($xstart, $yend)
        case $ALN_STARTS
            return prq:aln-starts-dt($xstart, $xend, $ystart, $yend)
        case $ALN_STARTED_BY
            return prq:aln-started-by-dt($xstart, $xend, $ystart, $yend)
        case $ALN_FINISHES
            return prq:aln-finishes-dt($xstart, $xend, $ystart, $yend)
        case $ALN_FINISHED_BY
            return prq:aln-finished-by-dt($xstart, $xend, $ystart, $yend)
        case $ALN_OVERLAPS
            return prq:aln-overlaps-dt($xstart, $xend, $ystart, $yend)
        case $ALN_OVERLAPPED_BY
            return prq:aln-overlapped-by-dt($xstart, $xend, $ystart, $yend)
        case $ISO_OVERLAPS
            return cts:or-query((
                prq:aln-equals-dt($xstart, $xend, $ystart, $yend),
                prq:aln-contains-dt($xstart, $xend, $ystart, $yend),
                prq:aln-started-by-dt($xstart, $xend, $ystart, $yend),
                prq:aln-finished-by-dt($xstart, $xend, $ystart, $yend),
                prq:aln-overlapped-by-dt($xstart, $xend, $ystart, $yend),
                prq:aln-overlaps-dt($xstart, $xend, $ystart, $yend),
                prq:aln-contained-by-dt($xstart, $xend, $ystart, $yend),
                prq:aln-starts-dt($xstart, $xend, $ystart, $yend),
                prq:aln-finishes-dt($xstart, $xend, $ystart, $yend)
            ))
        case $ISO_CONTAINS
            return cts:or-query((
                prq:aln-equals-dt($xstart, $xend, $ystart, $yend),
                prq:aln-contains-dt($xstart, $xend, $ystart, $yend),
                prq:aln-started-by-dt($xstart, $xend, $ystart, $yend),
                prq:aln-finished-by-dt($xstart, $xend, $ystart, $yend)
            ))
        case $ISO_PRECEDES
            return cts:or-query((
                prq:aln-meets-dt($xend, $ystart),
                prq:aln-before-dt($xend, $ystart)
            ))
        case $ISO_SUCCEEDS
            return cts:or-query((
                prq:aln-met-by-dt($xstart, $yend),
                prq:aln-after-dt($xstart, $yend)
            ))
        default return ()
};

declare private function prq:aln-equals-dt(
        $xstart as xs:QName,
        $xend as xs:QName,
        $ystart as xs:dateTime,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xstart, "=", $ystart),
        cts:element-range-query($xend, "=", $yend)
    ))
};

declare private function prq:aln-contains-dt(
        $xstart as xs:QName,
        $xend as xs:QName,
        $ystart as xs:dateTime,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xstart, "<", $ystart),
        cts:element-range-query($xend, ">", $yend)
    ))
};

declare private function prq:aln-contained-by-dt(
        $xstart as xs:QName,
        $xend as xs:QName,
        $ystart as xs:dateTime,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xstart, ">", $ystart),
        cts:element-range-query($xend, "<", $yend)
    ))
};

declare private function prq:aln-meets-dt(
        $xend as xs:QName,
        $ystart as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xend, "=", $ystart),
        ()
    ))
};

declare private function prq:aln-met-by-dt(
        $xstart as xs:QName,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xstart, ">", $yend),
        ()
    ))
};

declare private function prq:aln-before-dt(
        $xend as xs:QName,
        $ystart as xs:dateTime
) as cts:query
{
    cts:and-query((
        (),
        cts:element-range-query($xend, "<", $ystart)
    ))
};

declare private function prq:aln-after-dt(
        $xstart as xs:QName,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        (),
        cts:element-range-query($xstart, ">", $yend)
    ))
};

declare private function prq:aln-starts-dt(
        $xstart as xs:QName,
        $xend as xs:QName,
        $ystart as xs:dateTime,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xstart, "=", $ystart),
        cts:element-range-query($xend, "<", $yend)
    ))
};

declare private function prq:aln-started-by-dt(
        $xstart as xs:QName,
        $xend as xs:QName,
        $ystart as xs:dateTime,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xstart, "=", $ystart),
        cts:element-range-query($xend, ">", $yend)
    ))
};

declare private function prq:aln-finishes-dt(
        $xstart as xs:QName,
        $xend as xs:QName,
        $ystart as xs:dateTime,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xstart, ">", $ystart),
        cts:element-range-query($xend, "=", $yend)
    ))
};

declare private function prq:aln-finished-by-dt(
        $xstart as xs:QName,
        $xend as xs:QName,
        $ystart as xs:dateTime,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xstart, "<", $ystart),
        cts:element-range-query($xend, "=", $yend)
    ))
};

declare private function prq:aln-overlaps-dt(
        $xstart as xs:QName,
        $xend as xs:QName,
        $ystart as xs:dateTime,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xstart, "<", $ystart),
        cts:element-range-query($xend, ">", $ystart),
        cts:element-range-query($xend, "<", $yend)
    ))
};

declare private function prq:aln-overlapped-by-dt(
        $xstart as xs:QName,
        $xend as xs:QName,
        $ystart as xs:dateTime,
        $yend as xs:dateTime
) as cts:query
{
    cts:and-query((
        cts:element-range-query($xstart, ">", $ystart),
        cts:element-range-query($xstart, "<", $yend),
        cts:element-range-query($xend, ">", $yend)
    ))
};