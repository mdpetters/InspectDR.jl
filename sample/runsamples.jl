#Run sample code
#-------------------------------------------------------------------------------


#==Show results
===============================================================================#

for i in 1:3
	file = "./demo$i.jl"
	sepline = "---------------------------------------------------------------------"
	println("\nExecuting $file...")
	println(sepline)
	evalfile(file)
end

:SampleCode_Executed
