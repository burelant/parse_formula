# parse_formula
A chemical formula string parser for MATLAB

## Description

**parse_formula** is a string parser designed for MATLAB and that permits to convert linear or condensed chemical formulas into the corresponding raw chemical formulas. The script offers additional features, such as element counting, average molecular weight and monoisotopic mass calculation.

The script can be used to generate proper inputs for other scripts like `isoDalton_exact_mass` (see [DOI: 10.1016/j.jasms.2007.05.016](https://dx.doi.org/10.1016/j.jasms.2007.05.016)).

For now, the script does not support isotope labeling. Consequently, the molecular weights are not calculated when the input formula contains unstable elements.

## Syntax

The general syntax is `[a,b,c,d] = parse_formula(input)`, where:

* `input` is a scalar string containg the formula to parse (*e.g.* `"CH3CH2CH2CH3"`),
* `a` is the raw chemical formula returned after parsing as a scalar string,
* `b` a structure containing two fields, namely `element` and `count`, which associated every entry to a chemical element symbol and the corresponding count in the provided formula,
* `c` is the average molecular weight calculated for the compound, returned as a scalar double,
* `d` is the monoisotopic mass of the compound, return as a scalar double as well.

## Examples

`parse_formula("CH3CH2CH2CH3")` will produce the following output:
    
    ans = 
    
        "C4H10"
        
Strings containing brackets can also be provided as inputs:

    >> parse_formula("CH3(CH2)2CH3")
    
        ans = 
    
        "C4H10"
        
... as well as strings containing nested brackets:

    >> parse_formula("CH3(C(CH2)2)2CH3")

    ans = 

        "C8H14"
        
To obtain the list of the different elements in the provided formula with their respective counts, the following command can be used:

    >> [~,counts] = parse_formula("CH3(C(CH2)2)2CH3")

    counts = 

      2×1 struct array with fields:

        element
        count
        
The different entries generated each contain the symbol of the corresponding element (scalar string in field `element`) and the element counts (scalar double in field `count`):

    >> counts(1).element, counts(1).count

    ans = 

        "C"


    ans =

         8
         
  To calculate the average molecular weight and the monoisotopic mass, supplementary output argument must be required:
  
    >>  [formula,counts,MW,monoisotopic_mass] = parse_formula("CH3(C(CH2)2)2CH3")

    formula = 

        "C8H14"


    counts = 

      2×1 struct array with fields:

        element
        count


    MW =

      110.1971


    monoisotopic_mass =

      110.1096
      
## Errors to avoid

If non valid elements are provided in the input string, the script will return an error:

    >> parse_formula("CH3(Cn)2CH3")
    Error using parse_formula
    Cn is not a valid chemical element.
    
If elements having no stable isotope are provided in the input string, the script will return a warning message (without stopping code execution). In this case, the `c` and `d` output arguments will be returned as empty doubles.

    >> [a,b,c,d] = parse_formula("Pu(C2O4)2(H2O)6")
    Warning: At least one element of the string provided is unstable. The molecular weight and monoisotopic mass will not be
    calculated. 
    > In parse_formula (line 97) 

    a = 

        "C4H12O14Pu1"


    b = 

      4×1 struct array with fields:

        element
        count


    c =

         []


    d =

         []
         
## Future implementations

The following functionalities will be implemented in future versions:

* the possibility to use abbreviations (*e.g.* Me, Et, Pr, Bu, Ph, Cy...) for radicals in the input string,
* the possibility to specify isotopes in the input string (*e.g.* [13]C4H10, [13]C1C3H10...).
