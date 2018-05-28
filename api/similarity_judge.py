from sklearn.externals import joblib
import MeCab


"""
@:parameter
SKIP_LIST     -> POS_LISTに紛れ込んだものを排除する
ATTITUDE_LIST -> 返信度合いを高めるリスト.論文を参考
MECAB_PATH    -> 環境の違いによって変化する.浅田環境を取り敢えず
MODEL_PATH    -> 学習済みのモデルまでのパス
"""

SKIP_LIST = ["*"]
ATTITUDE_LIST =['？', 'ありがとう', 'お疲れ様']
MECAB_PATH = '-Ochasen -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd'
MODEL_PATH = './LearningModel/reply_judge.pkl'


class SimilarityCheck(object):
    def __init__(self, comments):
        self.gram_num = 2
        self.comments = sorted(comments, key=lambda x: x[0])

        self.mecab = MeCab.Tagger(MECAB_PATH)
        self.mecab.parse('')

        self.clf = joblib.load(MODEL_PATH)

    def return_api(self, comment_id, comment):
        comment_data = self.return_vec(comment_id, comment)
        reply_num = self.reply_element_get(comment_data)

        return reply_num

    def gram(self, comment):
        length = len(comment) - self.gram_num + 1  # た。みたいになるので+1
        element = [comment[i:i+self.gram_num] for i in range(length)]  # 要素番号

        return element

    """
    @:param
    base_judge  -> base:0 comp:1 比べられるコメントを飛ばすためのパラメータ
    """
    def steming(self, comment, base_judge=1):
        pos_list = ['名詞', '動詞', '形容詞']
        """
        形態素情報が欲しいためテキストで結果を返すparseではなくparseToNodeを使用する
        surface...表層形、feature...形態素情報
        """
        node = self.mecab.parseToNode(comment)

        node_list = []  # txt内のnodeをまとめたリスト
        attitude = 0
        while node:
            """
            feats返り値例 : ['動詞', '自立', '*', '*',
            '五段・ラ行', '体言接続特殊２', '戻る', 'モド', 'モド']
            よって原型を取得するにはnode6を取得すれば良い
            """
            feats = node.feature.split(',')
            if feats[6] in ATTITUDE_LIST and base_judge == 0:
                    attitude += 0.2
            elif feats[0] in pos_list and feats[6] not in SKIP_LIST:
                try:
                    node_list.append(feats[6])
                except Exception as e:
                    print("err:{0}, cause:{1}".format(str(node.surface), e))

            node = node.next  # ジェネレーター

        return node_list, attitude

    """
    @:return
    comment_data  -> [[ave, gram, stem, reply_num], [status], [....]]
    """
    def return_vec(self, id, comment):
        gram_base = self.gram(comment)
        steming_base, attitude = self.steming(comment, 0)

        comment_data = []
        for txt in self.comments[::-1]:  # 最新のコメントから遡るようにする
            if int(txt[0]) != id:
                comp_txt = txt[1]  # 返り値が(id, comment)になるので1番目nodeを取得
                gram_comp = self.gram(comp_txt)
                steming_comp = self.steming(comp_txt)

                gram_word = \
                    [b for b in gram_base for c in gram_comp if b == c]
                steming_word = \
                    [b for b in steming_base for c in steming_comp if b == c]

                gram_word_cnt = len(gram_word)
                gram_base_cnt = len(gram_base)
                steming_word_cnt = len(steming_word)
                steming_base_cnt = len(steming_base)

                # 1文字もしくは文字がない場合のエラー対策
                try:
                    gram_vec = round(gram_word_cnt/gram_base_cnt, 1)
                except ZeroDivisionError:
                    gram_vec = 0
                # stemingできないコメントを除外する
                try:
                    steming_vec = \
                        round(steming_word_cnt/steming_base_cnt, 1)
                    average_vec = \
                        round((gram_vec + steming_vec) / 2, 2) + attitude
                    similarity_data = \
                        [average_vec, gram_vec, steming_vec]
                except ZeroDivisionError:
                    steming_vec = 0
                    average_vec = gram_vec + attitude
                    similarity_data = \
                        [average_vec, gram_vec, steming_vec]

                # ここでリプライ判定を行う
                predict_status = self.clf.predict([similarity_data])
                similarity_data.append(txt[0])

                comment_data.append([similarity_data, predict_status[0]])

        return comment_data

    @staticmethod
    def reply_element_get(comments):
        max_similarity = 0
        reply_id = 400

        for ci in range(len(comments)):
            try:
                # replyかつ類似度を超えないと更新されない
                if comments[ci].index('reply') \
                        and max_similarity < comments[ci][0][0]:
                    max_similarity = comments[ci][0][0]
                    reply_id = comments[ci][0][3]
            except ValueError:
                pass

        return reply_id

if __name__ == "__main__":
    comment = "ありがとう！宿題やっておくね"
    comments = [(1, "悲しい事件だったね..."), (2, "暑いな"),
                (3, "今日飯尾ゼミ宿題あるよ"),
                (4, "家に帰りたい"), (5, "ん")]
    logic = SimilarityCheck(comments)
    # print(logic.return_vec(6, comment))
    # print(logic.return_api(6, comment))
