#Deviations

Our Setup

-IDE : intellij version 2025.3.4

-Model : Claude Sonnet 4.6 on claude.ai(website), effort is set to low in originally Author isn't listed what thinking mode but switched to claude Api platform after our replication didnt match

-New Account: no memory and fresh 

-Prompt pasted exactly from data.xmlx from column prompt ,sheet results-claude4.6 sonnet

-Started 2026-10-12, run by Maksims Gerkis and Marks Savenko


#Differences for the Original Paper

1. We used the claude.ai website, the authors used the API ,We also switched after test 2 after massive difference in output,but not in a loop output
2. We cant set the temperature on the website to default
3. Effort set to high in API on the website platform.claude.com/workspaces (Author didn't record the setting)
4. Only 25 cases not all 226
5. We ran it in October 2026 , Authors ran it earlier

#Log
- 12/10/2026 : Case 1,test ID2 Replicated the First test Case aside from text difference the way it was laid out output was "SAME" BUT The json  hypons were different = "" causing intej J to throw syntax error for json , Ran by Maksims
-
- 12/10/2026 : Case 2, test ID3 gave a completely different output to the Authors result decided to switch to API to keep as close to the paper as possible output "Not Same" ,Ran by Maksims
-
- 12/10/2026 : Case 3, test ID4 Replicated and received output "SAME" as Author and again sightly different text using the API gives the output and went back and reran the ID3 which different give the same output the first run now recieves excatly the same issue solved.,Ran by Maksims

- 12/10/2026 : Case 4, test ID6 Replicated output "SAME" but slighty different text,Ran by Maksims
-
- 12/10/2026 : Case 5, test ID7 Replicated output "SAME" but slighty different text,Ran by Maksims
-
- 12/10/2026 : Case 6, test ID8 Replicated output "SAME" but slighty different text,Ran by Maksims
-
- 12/10/2026 : Case 7, test ID9 Replicated output "SAME" but slighty different text,Ran by Maksims
-
- 12/10/2026 : Case 8, test ID10 Replicated output "SAME" noticed that if i copy from the prompt folder in the intel j same text for data.xlmx i copied in it gives me a different json text output ,from now keeping myself from just copying from the data.xlmx file.,Ran by Maksims
-
- 12/10/2026 : Case 9, test ID11 Replicated output "SAME" but slighty different text,Ran by Maksims
-
- 12/10/2026 : Case 10, test ID12 Replicated output "SAME" but slighty different text,Ran by Maksims
-
- 12/10/2026 : Case 11, test ID13 Replicated output "SAME" but slighty different text,Ran by Maksims
-
- 12/10/2026 : Case 12, test ID14 Replicated output "SAME" but slighty different text,Ran by Maksims
-
- 12/10/2026 : Case 13, test ID15 Replicated output "SAME" but slighty different text,also worth a mention there is text describing its reasoning for verdict which i didnt include as i dont see him including in the paper as well so he might have just left it out or possibly had metioned it somewhere. Example:
-
- 12/10/2026 : Case 14,test ID16 Replicated output "SAME" but slighty different text,ran by Marks
-
- 12/10/2026 : Case 15,test ID17 Replicated output "SAME" but slighty different text,ran by Marks
-
- 20/10/2026 : Case 16,test ID18 Replicated output "SAME" but slighty different text,ran by Marks
-
- 20/10/2026 : Case 17,test ID19 Replicated output "SAME" but slighty different text,ran by Marks
- 
- 20/10/2026 : Case 18,test ID20 Replicated a different output to the expected one,ran by Marks
- 
- 20/10/2026 : Case 19,test ID21 Replicated a different output to the expected one,ran by Marks
- 
- 20/10/2026 : Case 20,test ID50 Replicated output "SAME" but slighty different text,ran by Marks
- 
- 20/10/2026 : Case 21,test ID51 Replicated output "SAME" but slighty different text,ran by Marks
- 
- 20/10/2026 : Case 22,test ID53 Replicated output "SAME" but slighty different text,ran by Marks
- 
- 20/10/2026 : Case 23,test ID54 Replicated output "SAME" but slighty different text,ran by Marks
- 
- 20/10/2026 : Case 24,test ID55 Replicated output "SAME" but slighty different text,ran by Marks
-
- 20/10/2026 : Case 25,test ID56 Replicated output "SAME" but slighty different text,ran by Marks
-
- The key issue is in CODE2: B contains m() which uses A.this.k(). However, A.this is only valid inside an inner class (to refer to the enclosing instance of A). In B, which is a top-level class extending A, the expression A.this is not valid — B is not an inner class of A, so A.this cannot be used there. This will cause a compilation error.
-Ran by Maksims