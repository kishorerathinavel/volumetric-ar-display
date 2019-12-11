

import matplotlib.image as mpimg
import matplotlib.pyplot as plt
from pathlib import Path

def get_data_folder_path():
    return ("D:\\whp17\\Google Drive\\FocusPlaneGenerationData")




if __name__ == "__main__":
    
    
    data_folder_path = get_data_folder_path()

    filename = "%s\\Calibration\\Fov_Capture\\distortion_map1.png"%(data_folder_path)

    
    img =  mpimg.imread(filename)

    imgplot =  plt.imshow(img)
    plt.show()


    
    
    
