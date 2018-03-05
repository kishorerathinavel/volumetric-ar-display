clear all;

arr_content = [];
zero_code = dec2hex(0,4);
conv_factor = 21845/70;

for dec_code = 1:70
    hex_code = dec2hex(int16(dec_code*conv_factor),4);
    arr_elem = sprintf('{0x%s, 0x%s, 0x%s}', hex_code, zero_code, zero_code);
    arr_content = strcat(arr_content,',',arr_elem);
end
for dec_code = 1:70
    hex_code = dec2hex(int16(dec_code*conv_factor),4);
    arr_elem = sprintf('{0x%s, 0x%s, 0x%s}', zero_code, hex_code, zero_code);
    arr_content = strcat(arr_content,',',arr_elem);
end
for dec_code = 1:70
    hex_code = dec2hex(int16(dec_code*conv_factor),4);
    arr_elem = sprintf('{0x%s, 0x%s, 0x%s}', zero_code, zero_code, hex_code);
    arr_content = strcat(arr_content,',',arr_elem);
end
for dec_code = 1:70
    hex_code = dec2hex(int16(dec_code*conv_factor),4);
    arr_elem = sprintf('{0x%s, 0x%s, 0x%s}', hex_code, hex_code, hex_code);
    arr_content = strcat(arr_content,',',arr_elem);
end
arr_content(1) = [];

file_content = 'static uint16_t codes[][3] = {';
file_content = strcat(file_content, newline);
file_content = strcat(file_content, arr_content);
file_content = strcat(file_content, newline);
file_content = strcat(file_content, '};');
file_content = strcat(file_content, newline);

fID = fopen('codes.h','w');
fprintf(fID, '%s', file_content);
fclose(fID);



