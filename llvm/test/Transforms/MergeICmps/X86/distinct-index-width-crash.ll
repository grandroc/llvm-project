; RUN: not --crash opt < %s -passes=mergeicmps -verify-dom-info -disable-output

target triple = "x86_64"

; This is very much not an x86 ABI, in current use, but we're testing
; that we've fixed a bug where accumulateConstantOffset() was called incorrectly.
target datalayout = "e-p:64:64:64:32"

; Define a cunstom data layout that has index width < pointer width
; and make sure that doesn't mreak anything
define void @fat_ptrs(ptr dereferenceable(16) %a, ptr dereferenceable(16) %b) {
bb0:
  %ptr_a1 = getelementptr inbounds [2 x i64], ptr %a, i64 0, i64 1
  %ptr_b1 = getelementptr inbounds [2 x i64], ptr %b, i64 0, i64 1
  br label %bb1

bb1:                                              ; preds = %bb0
  %a0 = load i64, ptr %a
  %b0 = load i64, ptr %b
  %cond0 = icmp eq i64 %a0, %b0
  br i1 %cond0, label %bb2, label %bb3

bb2:                                              ; preds = %bb1
  %a1 = load i64, ptr %ptr_a1
  %b1 = load i64, ptr %ptr_b1
  %cond1 = icmp eq i64 %a1, %b1
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %necessary = phi i1 [ %cond1, %bb2 ], [ false, %bb1 ]
  ret void
}
