
# Examples for NFP P4
p4-generator/autogen.py --p4-template p4-generator/fastreact.p4 --c-template p4-generator/logic.c --max-disjunctive 1 --max-conjunctive 1 --output examples/fastreact-ps-nfp-p4-1x1.p4
p4-generator/autogen.py --p4-template p4-generator/fastreact.p4 --c-template p4-generator/logic.c --max-disjunctive 2 --max-conjunctive 2 --output examples/fastreact-ps-nfp-p4-2x2.p4
p4-generator/autogen.py --p4-template p4-generator/fastreact.p4 --c-template p4-generator/logic.c --max-disjunctive 4 --max-conjunctive 4 --output examples/fastreact-ps-nfp-p4-4x4.p4

# Examples for NFP Ext
p4-generator/autogen.py --p4-template p4-generator/fastreact-ext.p4 --c-template p4-generator/logic-ext.c --max-disjunctive 1 --max-conjunctive 1 --output examples/fastreact-ps-nfp-ext-1x1.p4
p4-generator/autogen.py --p4-template p4-generator/fastreact-ext.p4 --c-template p4-generator/logic-ext.c --max-disjunctive 2 --max-conjunctive 2 --output examples/fastreact-ps-nfp-ext-2x2.p4
p4-generator/autogen.py --p4-template p4-generator/fastreact-ext.p4 --c-template p4-generator/logic-ext.c --max-disjunctive 4 --max-conjunctive 4 --output examples/fastreact-ps-nfp-ext-4x4.p4

# Examples for t4p4s
p4-generator/autogen-t4p4s.py --p4-template p4-generator/fastreact-t4p4s.p4 --max-disjunctive 1 --max-conjunctive 1 --output examples/fastreact-ps-t4p4s-1x1.p4
p4-generator/autogen-t4p4s.py --p4-template p4-generator/fastreact-t4p4s.p4 --max-disjunctive 1 --max-conjunctive 4 --output examples/fastreact-ps-t4p4s-4x1.p4
p4-generator/autogen-t4p4s.py --p4-template p4-generator/fastreact-t4p4s.p4 --max-disjunctive 1 --max-conjunctive 8 --output examples/fastreact-ps-t4p4s-8x1.p4
p4-generator/autogen-t4p4s.py --p4-template p4-generator/fastreact-t4p4s.p4 --max-disjunctive 1 --max-conjunctive 1 --output examples/fastreact-ps-t4p4s-1x1.p4
p4-generator/autogen-t4p4s.py --p4-template p4-generator/fastreact-t4p4s.p4 --max-disjunctive 4 --max-conjunctive 1 --output examples/fastreact-ps-t4p4s-1x4.p4
p4-generator/autogen-t4p4s.py --p4-template p4-generator/fastreact-t4p4s.p4 --max-disjunctive 8 --max-conjunctive 1 --output examples/fastreact-ps-t4p4s-1x8.p4
