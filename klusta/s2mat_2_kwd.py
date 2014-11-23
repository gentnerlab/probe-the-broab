import argparse
import h5py as h5
import numpy as np

sites = {
    'A1x16': [6,11,3,14,1,16,2,15,5,12,4,13,7,10,8,9],
    'A1x32-Poly3': [0],
    }

def read_s2mat(mat,sites):
    n = np.inf
    index = np.zeros((len(sites),),np.int_)

    for ch, s in enumerate(sites):
        if n > f['Port_%s' % s]['length'][0,0]:
            n = f['Port_%s' % s]['length'][0,0]
        index[ch] = f['Port_%s' % s]['start'][0][0] / f['Port_%s' % s]['interval'][0][0]
    shape = (n,len(sites)) # samples,channels

    index -= index.max()
    index += -index.min()
    print index

    data = np.empty(shape,np.int16)

    for ch, s in enumerate(sites):
        start = index[ch]
        stop = int(index[ch]+n)
        data[:,ch] = f['Port_%s' % s]['values'][0,start:stop]

    f.close()

    return data

def write_kwd(kwd,data,recording=0):
    f = h5.File(kwd, 'w')
    grp = f.create_group('recordings/%i' % recording)
    grp.create_dataset('data', data=data)
    f.close()
    return True


parser = argparse.ArgumentParser(description='Convert a Spike2-exported MAT file to KWD.')
parser.add_argument('mat', type=str, nargs='+',
                   help='MAT files to be converted')
parser.add_argument('-t','--trode', type=str, action='store',default='A1x16',
                   help='electrode configuration')
parser.add_argument('-n','--name', type=str, action='store',default='concat',
                   help='name of kwd file')


def main(mat,trode,kwd):

    for r, m in enumerate(mat):
        data = read_s2mat(mat,sites[trode])
        name = 
        if write_kwd(kwd+'.kwd',data,recording=r):
            print '%s saved to %s as recording %s' % (mat,kwd+'.kwd',r)

if __name__ == '__main__':

    args = parser.parse_args()
    main(**args)