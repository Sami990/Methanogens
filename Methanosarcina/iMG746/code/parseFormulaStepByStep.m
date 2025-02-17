function [metabolites, stoichCoeffs] = parseFormula(formula)
    % Ensure formula is a valid string
    if isempty(formula) || ~ischar(formula)
        error('Reaction formula is empty or invalid.');
    end
    
    % Debugging: Print the formula before any normalization
    fprintf('Processing formula: "%s"\n', formula);
    
    % Normalize all possible arrow formats to a consistent format
    formula = strrep(formula, '→', '=>');  % Unicode arrow
    formula = strrep(formula, '->', '=>');  % Regular arrow
    formula = strrep(formula, '-->', '=>');  % Extended arrow
    formula = strrep(formula, '<=>', '=>');  % Reversible reaction arrow
    
    % Debugging: Print out the formula after normalization
    fprintf('Normalized formula: "%s"\n', formula);
    
    % Ensure there's a reaction separator ("=>")
    if ~contains(formula, '=>')
        error('Invalid reaction format (missing separator "=>" or "→"): %s', formula);
    end
    
    % Split reactants and products
    parts = split(formula, '=>');
    
    % Ensure the reaction has both sides (reactants and products)
    if length(parts) ~= 2
        error('Reaction does not have both reactants and products: %s', formula);
    end
    
    reactants = strtrim(split(parts{1}, '+'));  % List of reactants
    products = strtrim(split(parts{2}, '+'));  % List of products
    
    % Initialize output lists
    metabolites = {};
    stoichCoeffs = [];

    % Function to extract coefficient & metabolite name
    function [coeff, met] = extractCoefficient(metStr)
        % Remove leading/trailing spaces
        metStr = strtrim(metStr);
        
        % Skip if empty
        if isempty(metStr)
            return;
        end
        
        % Regular expression to match stoichiometry & metabolite names with compartments
        tokens = regexp(metStr, '^(\d*\.?\d*)\s*([a-zA-Z0-9\[\]_\(\)-]+(?:\[[a-zA-Z]+\])?)$', 'tokens', 'once');
        
        % If no match is found, handle it gracefully
        if isempty(tokens)
            error('Invalid metabolite format: "%s"', metStr);
        end
        
        % Parse coefficient (default to 1 if missing)
        if isempty(tokens{1})
            coeff = 1;  % Default coefficient
        else
            coeff = str2double(tokens{1});
        end
        
        % Parse metabolite name (including compartment)
        met = tokens{2};
    end

    % Process reactants (negative coefficients)
    for i = 1:length(reactants)
        try
            [coeff, met] = extractCoefficient(reactants{i});
            metabolites{end+1} = met;
            stoichCoeffs(end+1) = -coeff;  % Negative for reactants
        catch
            fprintf('Skipping invalid reactant: %s\n', reactants{i});
        end
    end

    % Process products (positive coefficients)
    for i = 1:length(products)
        try
            [coeff, met] = extractCoefficient(products{i});
            metabolites{end+1} = met;
            stoichCoeffs(end+1) = coeff;  % Positive for products
        catch
            fprintf('Skipping invalid product: %s\n', products{i});
        end
    end
    
    % Debugging: Print the final metabolites and stoichiometric coefficients
    fprintf('Metabolites: \n');
    disp(metabolites);
    fprintf('Stoichiometric Coefficients: \n');
    disp(stoichCoeffs);
end
