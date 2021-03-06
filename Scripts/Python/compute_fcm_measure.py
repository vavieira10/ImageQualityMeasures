from os import listdir
from os.path import isfile, join
import numpy as np
import sys
import math as mth
from subprocess import check_output

# Script for computing the feature correlation segmentation quality measures of images from a given input txt file
# As output, it prints the results

# Accessing the inputs from the terminal
input_file_normalized_images = sys.argv[1] 
input_file_normalized_masks = sys.argv[2] 
input_file_circle_params = sys.argv[3]
output_file = sys.argv[4]
database = sys.argv[5] if len(sys.argv) > 5 else '.'
map_file = sys.argv[6] if len(sys.argv) == 7 else ''

# IF THE DATABASE IS WARSAW, THEN ITS A SPECIAL CASE
special_case_dict = {}
extra_folder = 'DistortionFiles' if 'distortions' in map_file else 'NoDistortionFiles'
if database.lower() == 'warsaw' and map_file != '':
    with open('/home/vavieira/UnB/TCC/IrisDatabases/Warsaw-BioBase-Smartphone-Iris-v1.0/%s/%s.txt' % (extra_folder, map_file), "r") as f:
        for line in f:
            (key, value) = line.split("->")
            special_case_dict[key] = value.rstrip()
elif database.lower() == 'ubirisv1' and map_file != '':
    with open('/home/vavieira/UnB/TCC/IrisDatabases/UBIRISv1/%s/%s.txt' % (extra_folder, map_file), "r") as f:
        for line in f:
            (key, value) = line.split("->")
            special_case_dict[key] = value.rstrip()

# reading files and inserting class of images into three lists
with open(input_file_normalized_images, "r") as f:
    content_normalized_images = f.readlines()
content_normalized_images = [x.strip() for x in content_normalized_images] 

with open(input_file_normalized_masks, "r") as f:
    content_normalized_masks = f.readlines()
content_normalized_masks = [x.strip() for x in content_normalized_masks] 

with open(input_file_circle_params, "r") as f:
    content_circle_params = f.readlines()
content_circle_params = [x.strip() for x in content_circle_params] 

content_normalized_images.sort()
content_normalized_masks.sort()
content_circle_params.sort()

# Looping all the image filenames, in order to call the python feature correlation computation executable
qualities = []
max_value = 0.
min_value = 1.

with open(output_file, "w") as f:

    for i in range(0, len(content_normalized_images)):
        image_file = content_normalized_images[i].split('/')[-1].split('_imno')[0]
        
        # changing the image file if the database is wasrsaw
        if database.lower() == 'warsaw':
            image_file = "%s/session1/%s.jpg" % (special_case_dict[image_file], image_file) if "jpeg2000" not in image_file else "%s/session1/%s.jp2" % (special_case_dict[image_file], image_file)
        elif database.lower() == 'ubirisv1':
            image_file = "%s/%s.jpg" % (special_case_dict[image_file], image_file) if "jpeg2000" not in image_file else "%s/%s.jp2" % (special_case_dict[image_file], image_file)
        elif database.lower() == 'miche':
            image_file = "%s.jpg" % image_file if "jpeg2000" not in image_file else "%s.jp2" % image_file
        elif database.lower() == 'ubirisv2':
            image_file = "%s.tiff" % image_file if "jpeg2000" not in image_file else "%s.jp2" % image_file

        
        executable = ['python', '/home/vavieira/UnB/TCC/Codigos/ImageQualityMeasures/FeatureCorrelation/main.py', content_normalized_images[i], content_normalized_masks[i], content_circle_params[i]]
        quality = check_output(executable)
        
        # avoiding two 0.0 measures error
        quality = quality.split('\n')[0]

        print image_file, quality

        f.writelines([image_file, ' ', quality, '\n'])
        qualities.append(float(quality))

        if float(quality) > max_value:
            max_value = float(quality)

        if float(quality) < min_value:
            min_value = float(quality)

    mean = np.mean(qualities)
    variance = np.var(qualities)
    std_deviation = mth.sqrt(variance)

    f.writelines(['Mean ', str(mean), ', variance ', str(variance), ', std_deviation ', 
	str(std_deviation), ', max ', str(max_value), ', min ', str(min_value)])


