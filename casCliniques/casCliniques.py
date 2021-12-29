import datasets
import json
from urllib.request import urlopen

_DESCRIPTION = """\
casCliniques is a dataset of clinical cases scrapped from internet. 
"""
_HOMEPAGE_URL = "https://github.com/aneuraz/casCliniques"
_DATA_URLS = {"train" : _HOMEPAGE_URL + "/releases/download/1.0/trainset.json",
        "test" : _HOMEPAGE_URL + "/releases/download/1.0/testset.json"}


class CasCliniques(datasets.GeneratorBasedBuilder):
    VERSION = datasets.Version("1.0.0")

    def _info(self):
        return datasets.DatasetInfo(
            description=_DESCRIPTION,
            features=datasets.Features(
                {
                    "id": datasets.Value("string"),
                    "tokens": datasets.Sequence(datasets.Value("string")),
                    "ner_tags": datasets.Sequence(
                        datasets.features.ClassLabel(
                            names=[
                                 'B-DISORDER',
                                 'I-DISORDER',
                                 'B-PROCEDURE',
                                 'I-PROCEDURE',
                                 'B-LABVALUE',
                                 'I-LABVALUE',
                                 'B-DRUGS',
                                 'I-DRUGS',
                                 'B-PROFESSION',
                                 'I-PROFESSION',
                                 'B-RISK',
                                 'I-RISK',
                                 'B-ANATOMY',
                                 'I-ANATOMY',
                                 'O',
                                  ]
                        )
                    ),
                },
            ),
            supervised_keys=None,
            homepage=_HOMEPAGE_URL,
            #data_urls = _DATA_URLS
        )

    def _split_generators(self, dl_manager):
        
        downloaded_files = dl_manager.download_and_extract(_DATA_URLS)
        
        return [
            datasets.SplitGenerator(
                name=datasets.Split.TRAIN,
                gen_kwargs={"filepath": downloaded_files["train"]},
            ),
            datasets.SplitGenerator(
                name=datasets.Split.TEST,
                gen_kwargs={"filepath": downloaded_files["test"]},
            )
        ]

    def _generate_examples(self, filepath):
        sentence_counter = 0
        with open(filepath, encoding="utf-8") as f:
            dt = json.load(f)
            
            for sentence in dt: 
                id_ = f"{sentence['doc_id']}_{sentence['sent_id']}"
                
                yield id_, {
                    "id": id_, 
                    "tokens" : sentence["token"],
                    "ner_tags": self.convert_to_bio(sentence["label"])
                }
            
    @staticmethod
    def convert_to_bio(labels):
        previous_label = "None"
        new_labels= []
        for label in labels:
            if label not in ["None","O"]:
                if label == previous_label:
                    new_labels.append(f"I-{label.upper()}")
                else:
                    new_labels.append(f"B-{label.upper()}")
            else:
                new_labels.append(label)
            previous_label = label
        return new_labels