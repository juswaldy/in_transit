def SVM_Linear(X_train, X_test, y_train, y_test, df_current):
    clf = LinearSVC()
    clf.fit(X_train, y_train)
    Current_prediction = clf.predict(df_current) 
    Enrolled_prediction = collections.Counter(Current_prediction)
    
    prediction = clf.predict(X_test)
    a = []
    b = []
    c = []
    for i in range(5):
        accuracy = accuracy_score(y_test, prediction)  
        ra_score = roc_auc_score(y_test, prediction)
        f1_Score = f1_score(y_test, prediction)
        
        a.append(accuracy)
        accuracy_grouping = np.array(a)
        b.append(ra_score)
        ra_score_grouping = np.array(b)
        c.append(f1_Score)
        f1_Score_grouping = np.array(c)
    
    CV_Score = cross_val_score(clf, X_train, y_train, cv = 5)
    
    return Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score
