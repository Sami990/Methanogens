function model = build_grRules(model)
    % Initialize grRules cell array
    model.grRules = cell(size(model.rules));
    
    % Loop through each rule and replace x(number) with gene names
    for j = 1:length(model.rules)
        rule = model.rules{j};
        
        % Extract all occurrences of x(number) in the rule
        x_matches = regexp(rule, 'x\((\d+)\)', 'tokens');
        
        % Flatten the matches and convert to numerical indices
        gene_indices = unique(cellfun(@(c) str2double(c{1}), x_matches));
        
        % Replace x(number) with corresponding gene name from model.genes
        gene_expr = rule;
        for i = 1:length(gene_indices)
            idx = gene_indices(i);
            if idx > 0 && idx <= length(model.genes)
                gene_name = model.genes{idx};
                gene_expr = regexprep(gene_expr, ['x\(' num2str(idx) '\)'], gene_name);
            end
        end
        
        % Store the modified rule in model.grRules
        model.grRules{j} = gene_expr;
    end
end
