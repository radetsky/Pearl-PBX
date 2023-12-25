import os
import random
import shutil

# Ця програма генерує 100 директорій з випадковими файлами згідно ТЗ по колл-беку.

SRC_DIR = "./express64/"
DST_DIR = "./moh2023/"
LIB_DIR = "/var/lib/asterisk/moh/"
os.mkdir(DST_DIR)

with open(DST_DIR+"musiconhold.conf", 'wb') as conf:
    # Create 100 directories in the current directory
    for x in range(1, 100):
        conf_text = "[dir_" + str(x) + "]\nmode=files\ndirectory="+LIB_DIR+"moh2023/"+"dir_" + str(x) + "\nsort=alpha\n\n"
        conf.write(conf_text.encode('utf-8'))

        dirname = DST_DIR + "dir_" + str(x)
        print("Creating " + dirname)
        try:
            os.mkdir(dirname)
        except:
            pass
        # Create 100 files in each directory
        # Воспроизводим случайный ролик из 10 – 12
        block1 = ["10m", "11m", "12m", "10w", "11w", "12w"]
        reklama1 = SRC_DIR + "reklama1/" + random.choice(block1) + ".al"
        print("Copying " + reklama1 + " to " + dirname+"/"+"001.al")
        shutil.copy(reklama1, dirname+"/"+"001.al")

        y = 2
        while y < 100:
            # воспроизводим случайные ролики из (13-20) разряжая роликом 6
            block2 = ["13m", "14m", "15m", "16m", "17m", "18m", "19m", "20m", "13w", "14w", "15w", "16w", "17w", "18w", "19w", "20w"]

            reklama2 = SRC_DIR + "reklama2/" + random.choice(block2) + ".al"
            print("Copying " + reklama2 + " to " + dirname+"/"+"%03d.al" % (y))
            shutil.copy(reklama2, dirname+"/%03d.al" % (y))
            y += 1

            reklama2 = SRC_DIR + "reklama2/" + random.choice(block2) + ".al"
            print("Copying " + reklama2 + " to " + dirname+"/"+"%03d.al" % (y))
            shutil.copy(reklama2, dirname+"/%03d.al" % (y))
            y += 1

            rolik6 = SRC_DIR + "wait_short/" + random.choice(["1", "2"]) + ".al"
            print("Copying " + rolik6 + " to " + dirname+"/"+"%03d.al" % (y))
            shutil.copy(rolik6, dirname+"/%03d.al" % (y))
            y += 1
