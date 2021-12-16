from brat import load_from_brat
from spacy.lang.fr import French
import pandas as pd    
import random

class Brat2Conll: 
    def __init__(self):
        
        self.nlp = French()
        self.nlp.add_pipe("sentencizer")
        
        
    def brat_to_df(self, doc):
        d = self.nlp(doc['text'])
        df = self.sentences_to_df(d)
        df = self.add_entities_to_df(d, doc, df)
        df['doc_id'] = doc['doc_id'].replace('../','')
        return df
    
    def sentences_to_df(self,d):
        sent_id = 0
        token_id = 0
        df_list = []
        for sent in d.sents:

            tokens = [token for token in sent]
            last_token = token_id + len(tokens)
            df_list.append(pd.DataFrame({'sent_id':sent_id, 
                                'token':tokens,
                               'token_id':range(token_id, last_token)}))
            token_id = last_token
            sent_id += 1

        res = pd.concat(df_list)
        res['label'] = 'O'
        return res
    
    def add_entities_to_df(self, d, doc, df):
        if 'entities' in doc.keys():
            for ent in doc['entities']:
                for fragment in ent['fragments']:
                    span = d.char_span(fragment['begin'], fragment['end'], ent['label'],alignment_mode="expand")
                    df.iloc[span.start:span.end,3] = ent['label']
        return df

    
    
    def convert(self, input_dir:str):
        brat_files = list(load_from_brat(input_dir))
        df = [self.brat_to_df(doc) for doc in brat_files]
        return df
    
    
def split_train_test(df_agg_filtered, seed = 23, train_frac = 0.8):

    random.seed(seed)
    unique_ids = df_agg_filtered['doc_id'].unique()
    random.shuffle(unique_ids)

    max_train_position = round(unique_ids.shape[0] * train_frac)
    
    train_ids = unique_ids[:max_train_position]
    test_ids = unique_ids[max_train_position:]
    
    trainset = df_agg_filtered.loc[df_agg_filtered['doc_id'].isin(train_ids)]
    testset = df_agg_filtered.loc[df_agg_filtered['doc_id'].isin(test_ids)]
    
    trainset = dataframe_to_list(trainset)
    testset = dataframe_to_list(testset)
    
    return trainset, testset

def dataframe_to_list(dataset):
    dataset_list = []
    for index, row in dataset.iterrows():
        dataset_list.append({
            'doc_id' : row[0],
            'sent_id': row[1],
            'token': row[2],
            'label': row[3]
        })
    return dataset_list