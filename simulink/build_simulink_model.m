% Creates a starter Simulink thermal model. Requires Simulink.
model="TireThermalModel";
outPath=fullfile("simulink",model+".slx");

if bdIsLoaded(model); close_system(model,0); end
if isfile(outPath); delete(outPath); end

new_system(model);

add_block("simulink/Sources/In1",model+"/HeatInput_W","Position",[40 80 70 100]);
add_block("simulink/Sources/Constant",model+"/Ambient_C","Value","25","Position",[40 150 80 180]);
add_block("simulink/Math Operations/Sum",model+"/TempDifference","Inputs","+-","Position",[170 145 190 175]);
add_block("simulink/Math Operations/Gain",model+"/CoolingGain","Gain","35","Position",[220 145 270 175]);
add_block("simulink/Math Operations/Sum",model+"/NetHeat","Inputs","+-","Position",[270 80 290 110]);
add_block("simulink/Math Operations/Gain",model+"/ThermalCapacityInv","Gain","1/(10*1500)","Position",[320 80 370 110]);
add_block("simulink/Continuous/Integrator",model+"/TemperatureState","InitialCondition","80","Position",[420 80 450 110]);
add_block("simulink/Sinks/Out1",model+"/TireTemp_C","Position",[520 80 550 100]);

add_line(model,"HeatInput_W/1","NetHeat/1");
add_line(model,"NetHeat/1","ThermalCapacityInv/1");
add_line(model,"ThermalCapacityInv/1","TemperatureState/1");
add_line(model,"TemperatureState/1","TireTemp_C/1");
add_line(model,"TemperatureState/1","TempDifference/1","autorouting","on");
add_line(model,"Ambient_C/1","TempDifference/2","autorouting","on");
add_line(model,"TempDifference/1","CoolingGain/1");
add_line(model,"CoolingGain/1","NetHeat/2","autorouting","on");

save_system(model,outPath);
close_system(model);
fprintf("Created %s\n",outPath);
