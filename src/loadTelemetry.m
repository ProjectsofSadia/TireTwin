function tbl = loadTelemetry(filename)
%LOADTELEMETRY Load TireTwin v2 telemetry.
tbl = readtable(filename);
required = ["Time","Distance","Speed","Throttle","Brake","RPM","Gear","DRS","X","Y"];
missing = required(~ismember(required,string(tbl.Properties.VariableNames)));
if ~isempty(missing)
    error("Missing required telemetry columns: %s",strjoin(missing,", "));
end
end
