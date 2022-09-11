function [formula_string,formula_table,MW,monoisotopic_mass] = ...
    parse_formula(formula)

% PARSE_FORMULA parses developed or semi-developed chemical formulas
% provided as scalar strings to return the corresponding raw formula, 
% element counts, average molecular weight and monoisotopic molecular 
% weight.
%
% Author: phenan08 (https://github.com/phenan08/parse_formula)
%
% Input: ==================================================================
%   * formula     scalar string containing the formula to parse (e.g.
%     "CH3CH2CH2CH2CH3", or "(CH3)2(CH2)3")
%
% Outputs: ================================================================
%   * formula_string      a scalar string containing the raw formula
%   * formula_table       a structure containing the list and counts of the
%     different elements found in the formula
%   * MW                  the average molecular weight (returned as double) 
%     of the compound
%   * monoisotopic_mass   the monoisotopic mass (returned as double) of the
%     compound

arguments
    formula string {mustBeTextScalar}
end

load chemical_element_list.mat

pat_elements = characterListPattern("ABCDEFGHIJKLMNOPQRSTUVWXYZ") + ...
    optionalPattern(characterListPattern("abcdefghijklmnopqrstuvwxyz")) ...
    + optionalPattern(digitsPattern) ;

pat_brackets = "(" + asManyOfPattern(pat_elements) + ")" + ...
    optionalPattern(digitsPattern) ;

% 1. Parse brackets
% =================

list = extract(formula,pat_brackets) ;

while isempty(list) == false
    for i = 1:numel(list)
        coeff = extract(list(i),")"+digitsPattern) ;
        argument = replace(list(i),coeff,"") ;
        argument = replace(argument,"(","") ;
        coeff = replace(coeff,")","") ;
        coeff = str2double(coeff) ;
        new_string = join(repmat(argument,1,coeff),"") ;
        formula = replace(formula,list(i),new_string) ;
    end
    list = extract(formula,pat_brackets) ;
end

% 2. Parse elements
% =================

list = extract(formula,pat_elements) ;

elements = strings(numel(list),1) ;
coeffs = zeros(numel(list),1) ;
for i = 1:numel(list)
    elements(i) = replace(list(i),digitsPattern,"") ;
    coeff = extract(list(i),digitsPattern) ;
    if isempty(coeff)
        coeffs(i) = 1 ;
    else
        coeffs(i) = str2double(coeff) ;
    end
end

[elements, ~, idx] = unique(elements) ;

element_idx = zeros(numel(elements),1) ;
for i = 1:numel(elements)
    formula_table(i,1).element = elements(i) ;
    formula_table(i,1).count = sum(coeffs(idx == i)) ;
    try
        element_idx(i) = find([chemical_element_list.symbol]==elements(i)) ;
    catch
        error(join([elements(i) " is not a valid chemical element."],"")) ;
    end
end

formula_string = [[formula_table.element] ; string([formula_table.count])] ;
formula_string = join(formula_string,"",1) ;
formula_string = join(formula_string,"",2) ;

% Check for unstable elements and calculation of average molecular weight
% and monoisotopic mass
% =======================================================================

test = sum([chemical_element_list(element_idx).isStable]) == ...
    numel(element_idx) ;

if test == 0
    warning("At least one element of the string provided is unstable." + ...
        " The molecular weight and monoisotopic mass will not be " + ...
        " calculated.") ;
    MW = [] ;
    monoisotopic_mass = [] ;
else
    MW = sum([formula_table.count].* ...
    [chemical_element_list(element_idx).average_mass]) ;
    monoisotopic_mass = sum([formula_table.count].* ...
        [chemical_element_list(element_idx).monoisotopic_mass]) ;
end

end