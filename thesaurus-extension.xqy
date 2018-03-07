xquery version "1.0-ml";

module namespace thsr-ext = "http://www.marklogic.com/thesaurus/thesaurus-ext";

import module namespace thsr="http://marklogic.com/xdmp/thesaurus" at "/MarkLogic/thesaurus.xqy";

declare variable $THESAURUS-URI := "thesaurus.xml";

declare function thsr-ext:lookup(
  $phrase as xs:string,
  $fn as function() as item()*
) as element(thsr:entry)*
{
  let $expanded-phrases := thsr-ext:get-synonyms($phrase,$fn)
  return
    if (fn:count($expanded-phrases) eq 0)
    then ()
    else  element thsr:entry {
      element thsr:term {$phrase},
      for $syn in $expanded-phrases
      return element thsr:synonym {
        element thsr:term {$syn}
      }
    }
};

(:
  This function will return a sequence of synonym terms as a string
:)
declare private function thsr-ext:_get-synonyms(
  $phrase as xs:string,
  $fn as function() as item()*
) as xs:string*
{
  let $lookup := $fn (:thsr:lookup($THESAURUS-URI, fn:lower-case(fn:normalize-space($phrase))):)
  return if (fn:empty($lookup)) then () else $lookup//thsr:synonym/thsr:term/text()
};

(:
  This function will return a sequence of strings bases on the total number of words in the given $text
  eg:
  $text := hello world, here I am
  Returns: 'hello', 'world', 'here', 'I', 'am', 'hello world', 'here I', 'I am', 'world, here', 'here I am', 'hello world, here', 'world, here', 'world, here I', 'hello world, here I', 'world, here I am'
:)
declare private function thsr-ext:get-n-grams(
  $text as xs:string
)
{
  let $cnt := fn:count(cts:tokenize(fn:replace(fn:normalize-unicode($text, 'NFD'), '[\p{M}]', ''))(:[. instance of cts:word]:))
  return if ($cnt > 1) then thsr-ext:get-n-grams($text, $cnt - 1) else $text
};

declare private function thsr-ext:get-n-grams(
  $text as xs:string,
  $j as xs:long
)
{
  let $words := cts:tokenize(fn:replace(fn:normalize-unicode($text, 'NFD'), '[\p{M}]', ''))(:[. instance of cts:word]:)
  let $n-grams := (1 to $j)
  for $n in $n-grams
  for $word at $pos in $words[fn:position() <= (fn:last() - $n + 1)] (: syntax highlight fix: > :)
  let $words := $words[$pos to ($pos + $n - 1)]
  let $phrase := fn:string-join($words, '')
  let $before := fn:substring-before($text,$phrase)
  let $after :=  fn:substring-after($text,$phrase)
  where not(fn:empty($phrase) or $phrase eq ' ') and $words[1][. instance of cts:word] and $words[last()][. instance of cts:word]
  return
    $phrase
};

declare function thsr-ext:expand-term(
  $phrase as xs:string
) as xs:string*
{
  ($phrase, thsr-ext:get-synonyms($phrase))
};

declare function thsr-ext:get-synonyms(
  $phrase as xs:string,
  $fn as function() as item()*
) as xs:string*
{
  let $synonyms := thsr-ext:_get-synonyms($phrase, $fn)
  let $expanded-phrases := (
    if (fn:count($synonyms) > 0)
    then $synonyms
    else (
      let $phrases := thsr-ext:get-n-grams($phrase)
      for $p in $phrases
      let $before := fn:substring-before($phrase,$p)
      let $after :=  fn:substring-after($phrase,$p)
      let $synonyms := thsr-ext:_get-synonyms($p)
      return if (fn:count($synonyms) > 0)
      then for $syn in $synonyms return fn:string-join(($before,$syn,$after),'')
      else ()
    )
  )
  return $expanded-phrases
};

declare function thsr-ext:expand(
    $phrase as xs:string,
    $fn as function() as item()*,
    $options as element(s:options)?
) as cts:query
{
    thsr:expand(
        cts:word-query($phrase,(for $opt in $options return $opt//s:term-option/text())),
        $fn, (:thsr-ext:lookup($phrase),:)
        (),(),()
    )
};

declare function thsr-ext:expand-parse-tree(
  $phrase as xs:string,
  $options as element(s:options)?
) as cts:query
{
  let $expanded-search-phrases :=  thsr-ext:expand-term($phrase)
  let $query :=
    if (fn:count($expanded-search-phrases) eq 1) then
      cts:query(s:parse($expanded-search-phrases,$options))
    else
      cts:or-query((
        for $term in $expanded-search-phrases
        return  cts:query(s:parse($term,$options))
      ))
  return $query
};
